import boto3
import datetime
import time

FMT = '%d-%m-%Y'
today = datetime.datetime.now()
today_fmt = today.strftime('%d-%m-%Y')
today_fmt_hash = today.strftime('%d/%m/%Y - %H.%M.%S')

delete_day = datetime.date.today() + datetime.timedelta(days=1)
delete_day_fmt = delete_day.strftime('%d-%m-%Y')

def lambda_handler(event,context):

    ec2 = boto3.resource('ec2', region_name = 'us-east-1')
    
    filters = [{
            'Name': 'tag:Auto-Snapshot',
            'Values': ['yes']
        },
        {
            'Name': 'instance-state-name', 
            'Values': ['running']
        }
    ]
    #filter the instances
    instances = ec2.instances.filter(Filters=filters)

    for i in instances.all():
        for tag in i.tags:
            if tag['Key'] == 'Name':
                name = tag['Value']
            elif tag['Key'] == 'Product':
                product = tag['Value']
            elif tag['Key'] == 'Environment':
                environment = tag['Value']
        
        print("GENERATING AMAZON MACHINE IMAGE FOR " + i.id + " ....")
        image = i.create_image(Description="Auto-backup from " + i.id + " - " + today_fmt, Name = "Auto-backup - " + i.id + " from " + today_fmt_hash , NoReboot=True)
        image_tags = image.create_tags(
            Tags = [
                {
                    'Key': 'Name',
                    'Value': name
                },
                {   
                    'Key': 'InstanceId',
                    'Value': i.id
                },
                {
                    'Key': 'Product',
                    'Value': product
                },
                {
                    'Key': 'Environment',
                    'Value': environment
                },
                {
                    'Key': 'DeleteOn',
                    'Value': delete_day_fmt
                }
            ]
        )
        time.sleep(1)
        for block in image.block_device_mappings:
            try:
                snapshot = ec2.Snapshot(block['Ebs']['SnapshotId'])
                snapshot.create_tags(
                    Tags = [
                        {
                            'Key': 'Name',
                            'Value': name
                        },
                        {
                            'Key': 'Auto-Generated',
                            'Value': 'yes'
                        },
                        {
                            'Key': 'DeleteOn',
                            'Value': delete_day_fmt
                        },
                        {
                            'Key': 'ImageId',
                            'Value': image.id
                        }
                    ]
                )
            except:
                pass

        print("GENERATED AMI WITH ID: " + image.id)
        
        
        
        
    #################DELETION RUTINE##############
        
        
    print("\n\n DELETING MARKED SNAPSHOTS")
    filters_by_delete_on = [
        {
            'Name': 'tag:DeleteOn',
            'Values':['*']
            }
        ]
        
    filters_by_ami_id = [
        {
            'Name': 'tag:ImageId',
            'Values':['*']
            }
        ]
    images = ec2.images.filter(Filters=filters_by_delete_on).all()
    snapshots = ec2.snapshots.filter(Filters=filters_by_delete_on).all()
    for image in images:          
        #creation_date = image.creation_date
        #creation_date_fmt = datetime.datetime.strptime( creation_date, '%Y-%m-%dT%H:%M:%S.%fZ').strftime('%d-%m-%Y')
        #print creation_date_fmt
        for tag in image.tags:
            if tag['Key'] == 'DeleteOn':
                delete_on = tag['Value']
            
        tdelta = datetime.datetime.strptime(delete_on, FMT) - datetime.datetime.strptime(today_fmt, FMT)


        if tdelta.days <= 0:
            print("SE ELIMINARA LA AMI: "  + image.id)
            image.deregister()

    for snapshot in snapshots:          
        #creation_date = image.creation_date
        #creation_date_fmt = datetime.datetime.strptime( creation_date, '%Y-%m-%dT%H:%M:%S.%fZ').strftime('%d-%m-%Y')
        #print creation_date_fmt
        for tag in snapshot.tags:
            if tag['Key'] == 'DeleteOn':
                delete_on = tag['Value']
            
        tdelta = datetime.datetime.strptime(delete_on, FMT) - datetime.datetime.strptime(today_fmt, FMT)


        if tdelta.days <= 0:
            print("SE ELIMINARA EL SNAPSHOT: "  + snapshot.id)
            snapshot.delete()