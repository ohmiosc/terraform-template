Feature: Caracteristicas de la Prueba (Todos los recursos deben tener Etiquetas)


  Scenario Outline: Ensure that specific tags are defined
    Given I have resource that supports tags_all defined
    When it has tags_all
    Then it must contain tags_all
    Then it must contain "<tags>"
    And its value must match the "<value>" regex

    Examples:
        | tags        | value              |
        | Environment | ^(prod\|pre\|dev)$ |
        | Project     | .+                 |
        | Product     | .+                 |