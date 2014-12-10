Contentful Generic-importer
=================

## Description

Migrate data from database to the [Contentful](https://www.contentful.com) platform.

This tool fetch data from database and save as JSON files on your local hard drive. It will allow you to import database's data to Contentful.

## Installation

``` bash
gem install database-exporter
```

This will install a ```database-exporter``` executable.

## Usage

To use the tool you need to specify your Contentful credentials in a YAML file and database configuration .
For example in a ```settings.yml``` file:

``` yaml
#Contentful
ACCESS_TOKEN: access_token
ORGANIZATION_ID: organization_id
```

**Your Contentful access token can be easiest created using the [Contentful Management API - documentation](https://www.contentful.com/developers/documentation/content-management-api/#getting-started)**
The Contentful organization id can be found in your account settings.

Once you installed the Gem and created the YAML file with the settings you can invoke the tool using:

```
database-exporter --config-file settings.yml  --action
```

## Actions
To display all actions in console, use command:
```
database-exporter -h
```
#### --list-tables
This action will create JSON file with all table names from your database and save it to ```data_dir/table_names.json```. These values ​​will be needed to export data from the database.

Specify path, where the should be saved, you can do that in **settings.yml** file.

```yml
 data_dir: PATH_TO_ALL_DATA
 table_names: data_dir/table_names.json
```
#### --extract-to-json

In [settings.yml](https://github.com/contentful/generic-importer.rb#setting-file) file, you can define table names, which data you want to export from database. The easiest way to get table names is to use the command [--list-tables](https://github.com/contentful/generic-importer.rb#--list-tables)

After we specify the tables, that we want to extract, and run command ```--export-json ```, each object from database will be save to separate JSON file.

Path to JSON data: ***data_dir/entries/content_type_name_defined_in_mapping_json_file***

#### --prepare-json

Prepare JSON files to import form to Contentful platform.

# EXPORT PART

### FIELDS

To change name of model name field for new one, we need to add mapping for that field:
```
 "fields": {
             "model_name": "new_api_contentful_field_name",
             "model_name": "new_api_contentful_field_name",
             "model_name": "new_api_contentful_field_name"
         },
```


### RELATIONS TYPES

#### belongs_to

This method should only be used if this class contains the foreign key. If the other class contains the foreign key, then you should use has_one instead.

Example:
```
    "Comments": {
        "content_type": "Comments",
        "type": "entry",
        "fields": {
        },
        "links": {
           "belongs_to": [
                          {
                              "relation_to": "ModelName",
                              "foreign_id": "model_foreign_id"
                          }
                      ]
        }
    }
```
It will assign the associate object, save his ID ```(model_name + id)``` in JSON file.

Result:
```
{
  "id": "comments_1",
  ...
  "job_add_id": {
    "type": "Entry",
    "id": "model_name_3"
  },
}

```

#### has_one

This method should only be used if the other class contains the foreign key. If the current class contains the foreign key, then you should use belongs_to instead.

 Example:

 ```
     "Users": {
         "content_type": "Users",
         "type": "entry",
         "fields": {
         },
         "links": {
             "has_one": [
                 {
                     "relation_to": "ModelName",
                     "primary_id": "primary_key_name"
                 }
             ]
         }
     }
 ```

Results:
It will assign the associate object, save his ID ```(model_name + id)``` in JSON file.

 ```
 ...
  "model_name": {
    "type": "profiles",
    "id": "content_type_id_3"
  }
 ```

#### many

```
    "ModelName": {
    ...
        },
        "links": {
            "many": [
                        {
                            "relation_to": "related_model_name",
                            "primary_id": "primary_key_name"
                        }
                    ],
                }
        }
```

It will assign the associate objects, save his ID ```(model_name + id)``` in JSON file.

Results:

Example:
```
{
  "id": "content_type_id",
  "comments": [
    {
      "type": "related_content_type_name",
      "id": "related_model_name_id"
    },
    {
      "type": "related_content_type_name",
      "id": "related_model_name_id"
    },
    {
      "type": "related_content_type_name",
      "id": "related_model_name_id"
    },
    {
      "type": "related_content_type_name",
      "id": "related_model_name_id"
    }
  ]
}
```

#### many_through

Example:

```
        "links": {
            "many_through": [
                {
                    "relation_to": "related_model_name",
                    "primary_id": "primary_key_name",
                    "foreign_id": "foreign_key_name",
                    "through": "join_table_name"
                }
            ]
        }
```

It will map join table and save objects IDs in current model.

Results:

```
  "content_type_name": [
    {
      "type": "content_type_name",
      "id": "related_model_foreign_id"
    },
    {
      "type": "content_type_name",
      "id": "related_model_foreign_id"
    },
    {
      "type": "content_type_name",
      "id": "related_model_foreign_id"
    }
  ]
```
#### aggregate_belongs

It will save value with key of related model
```
        "links": {
            "many_through": [
                {
                    "relation_to": "related_model_name",
                    "primary_id": "primary_key_name",
                    "field": "aggregated_field_name"
                }
            ]
        }
```


## Contentful Structure

This file represents our Contentful structure.

Example:

```
{
    "Comments": {
        "id": "comment",
        "description": "",
        "displayField": "title",
        "fields": {
            "title": "Text",
            "content": "Text"
        }
    },
    "JobAdd": {
        "id": "job_add",
        "description": "Add new job form",
        "displayField": "name",
        "fields": {
            "name": "Text",
            "specification": "Text",
            "Images": {
                "id": "image",
                "link_type": "Asset"
            },
            "Comments": {
                "id": "comments",
                "link_type": "Array",
                "type": "Entry"
            },
            "Skills": {
                "id": "skills",
                "link_type": "Array",
                "type": "Entry"
            }
        }
    }
```
Key names "Images", "Comments", "Skills" are the equivalent of the content types name specified in the file **mapping.json**.

Example:
```
``
     "SkillsTableName": {
         "content_type": "Skills",
         "type": "entry",
         "fields": { ... }
```

**IMPORTANT**

To create any relationship between objects, we must remember that the content names given in the  **mapping.json** file, must cover with names in **contentful_structure.json** file.

## Setting file

To use this tool, you need to create YML file and define all needed parameters.

#### Database Connection - Define Adapter

Assuming we are going to work with MySQL, SQlite or PostgreSQL database, before connecting to a database make sure of the setup YML file with settings.
Following is the example of connecting with MySQL database "test_import"

```yml
adapter: mysql2
user: username
host: localhost
database: test_import
password: secret_password
```

**Available Adapters**

```
PostgreSQL => postgres
MySQL => mysql2
SQlite => sqlite
```

**Define Exporter**

By default we set Database Exporter. To change Exporter you need to specify addition argument ``` --exporter EXPORTER ```. For now there is only exporter available.

``` database-exporter --config-file settings.yml   --action ```

#### Mapped tables

Before export data from database, you need to exactly specify which tables will be exported.
To fastest way to get that names is use command: [--list-tables](https://github.com/contentful/generic-importer.rb#--list-tables)

Selected table names enter to **settings.yml** file, parameter
 ```yml
mapped:
    tables:
```
Example:
 ```yml
mapped:
 tables:
  - :example_1
  - :example_2
  - :example_3
  - :example_4
```

### Mapping

* JSON file with mapping structure which defines relations between models.

```yml
mapping_dir: example_path/mapping.json
```

* JSON file with contentful structure
```yml
contentful_structure_dir: contentful_import_files/contentful_structure.json
```
* [Dump JSON file](https://github.com/contentful/generic-importer.rb#--convert-content-model-to-json) with content types from contentful model:

```yml
import_form_dir: contentful_import_files/contentful_structure.json
```



