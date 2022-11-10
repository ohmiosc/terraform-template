import boto3
import logging
import time
from botocore.vendored import requests
import json

#setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)
webhook_url = 'https://hooks.slack.com/services/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'


regions = ['us-west-2','eu-west-1', 'ap-northeast-1','eu-west-2']
#regions = ['ap-northeast-1']

def lambda_handler(event, context):
    # Use the filter() method of the instances collection to retrieve
    # all running EC2 instances.
    # all running AutoScaling Groups

    for region in regions:
        #define the connection
        ec2 = boto3.resource('ec2', region_name = region)
        
        filters = [{
                'Name': 'tag:Auto-Off',
                'Values': ['yes']
            },
            {
                'Name': 'instance-state-name', 
                'Values': ['running']
            }
        ]
        #filter the instances
        instances = ec2.instances.filter(Filters=filters)
        print(instances)
        #shutting down instances
        #make sure there are actually instances to shut down
        print ("Shutting Down Instances in " + region)
        for instance in instances:
            try:
                #perform the shutdown
                response = ec2.Instance(instance.id).stop()
                #print the instances for logging purposes
                print (' --> Stopping Instance {}'.format(instance.id))
            except:
                print ((instance.id + "It's an spot instance and can't stop it"))
        
        #APAGADO DE AUTOSCALING
        autoscaling = boto3.client('autoscaling', region_name = region)

        #Defining filters that an instance should have in order to be stopped
        paginator2 = autoscaling.get_paginator('describe_auto_scaling_groups')
        page_iterator2 = paginator2.paginate(PaginationConfig={'PageSize': 100})
        auto_scaling_groups = page_iterator2.search('AutoScalingGroups[] | [?contains(Tags[?Key==`{}`].Value, `{}`)]'.format('Auto-Off', 'yes'))
        
        #shutting off autoScaling groups
        print ("Shutting Down Auto Scaling Groups") 
        for asg in auto_scaling_groups:
            if asg['MinSize'] > 0:
                print(" --> Scaling down AutoScaling Group {}".format(asg['AutoScalingGroupName']))
                response2 = autoscaling.update_auto_scaling_group(AutoScalingGroupName=asg['AutoScalingGroupName'],MinSize=0)
            else:
                print("AutoscalingGroup " + asg['AutoScalingGroupName'] + " it's already with 0 as MinSize")
           
            if asg['DesiredCapacity'] > 0:
                print(" --> Scaling down AutoScaling Group {}".format(asg['AutoScalingGroupName']))
                response2 = autoscaling.update_auto_scaling_group(AutoScalingGroupName=asg['AutoScalingGroupName'],DesiredCapacity=0)

            else:
                print("AutoscalingGroup " + asg['AutoScalingGroupName'] + " it's already with 0 as DesiredCapacity")
        
        print ("SE REALIZÓ EL APAGADO DE AUTOSCALING EN " + region)

        
        
                
                
        #APAGADO DE FARGATE TASKS
        ecs = boto3.client('ecs', region_name = region)
        cluster2=ecs.list_clusters()
        #print("ARN de cluster:")
        clusters=cluster2['clusterArns']
        #print(clusters)
        preclusters=[]
        for cluster in clusters:
            if "pre1a" in cluster:
                print("cluster PRE1a: "+ cluster)
            elif "jenkins" in cluster:
                print("cluster Jenkins: "+ cluster)
            else:
                preclusters.append(cluster)
        #print("Clusters")
        #print(preclusters) 
        for precluster in preclusters:
        #perform the shutdown
            startpos1= precluster.rfind('/')+1
            clustername=precluster[startpos1:200]
            paginator = ecs.get_paginator('list_services')
            response_iterator = paginator.paginate(cluster=clustername,launchType='FARGATE',PaginationConfig={'PageSize':100})
            
            for each_page in response_iterator:
                for each_arn in each_page['serviceArns']:
                    #
                    if "pre1a" in each_arn:
                        print("Servicio PRE1a: "+ each_arn)
                    if "jenkins" in each_arn:
                        print("servicio Jenkins: "+ each_arn)
                    if "staging" in each_arn:
                        print(">>> Except shutdown Service Syndeo(staging): {}".format(each_arn))
                        continue
                    if "pgp-pre-topps" in each_arn:
                        print(">>> Except shutdown TOOPS: {}".format(each_arn))
                        continue
                    if "pe-pre1a-ms-payments" in each_arn:
                        print(">>> Except shutdown ms-payments: {}".format(each_arn))
                        continue
                    else:
                        response2 = ecs.update_service(cluster=clustername,
                        service = each_arn,
                        desiredCount = 0
                        )
                        #print(json.dumps(response2, indent=4, default=str))
                    #
                    
                    
                    


    

    #slack posting webhook
    slack_data = {'channel': "infra", 'username': "AWS Lambda", 'icon_url': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/AWS_Lambda_logo.svg/2000px-AWS_Lambda_logo.svg.png", "attachments":[{"color":"good","title":"SHUTTING DOWN ENVIRONMENTS\n [STAGING] & [DEVELOPMENT]","title_link":"https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=/aws/lambda/infrastructure-auto-stop-instances;streamFilter=typeLogStreamPrefix"}]}
    response = requests.post(webhook_url, data=json.dumps(slack_data), headers={'Content-Type': 'application/json'})