## [Released]

## [1.0.28] - 2023-04-04
- Error :access_denied was added to Result model.

## [1.0.27] - 2023-03-19
- Function to_json was renamed to function as_json because its name is more appropriate. Function to_json was added.

## [1.0.26] - 2023-03-03
- Custom result attribute was added to Result model. 

## [1.0.25] - 2023-02-23
- Function error_body was added to Anoubis::ApiService. This function return Hash symbolized error body from API response.

## [1.0.24] - 2023-02-16
- Anoubis::ApiService errors redirected to Rails.logger.

## [1.0.23] - 2023-02-15
- Result model was added in Anoubis::ApiService initialization.

## [1.0.22] - 2023-02-13
- Anoubis::ApiService was added. Service for create API request and return parsed data.

## [1.0.21] - 2023-01-26
- Messages were added to Result model 

## [1.0.18] - 2022-09-29
- MySQL dependency was removed. (Library can be used with MySQL and PostgreSQL databases)

## [1.0.12] - 2022-06-07
- Error with export XLS data was fixed.

## [1.0.11] - 2022-05-18
- Datetime field view representation was fixed.
