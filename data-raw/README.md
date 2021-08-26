### db_info_table.csv

A database version and url lookup table.

- **db**: database name
- **version**: database version
- **url_num**: url number (some databases are spread over multiple files)
- **url**: file url where the database can be downloaded

### material_thesaurus.csv

A thesaurus for material classes. More info about the version history in material_thesaurus_comments.md.

- **cor**: fixed name
- **var**: variations

### variable_definition.csv

Definition of the variables in a c14_date_list

- **c14bazAAR_variable**: name of variable in c14bazAAR
- **type**: data type of variable in R
- **definition**: meaning of variable
- **source**: is the variable imported (databases) or generated (c14bazAAR)

### variable_reference.csv

Which variables in a c14_date_list equal the ones in the source databases?

- **c14bazAAR_variable**: name of variable in c14bazAAR
- **database**: source database
- **database_variable**: name of variable in the respective source database

