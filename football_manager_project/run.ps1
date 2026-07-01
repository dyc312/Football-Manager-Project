param(
    [Parameter(Mandatory=$true)]
    [string]$DbPassword,

    [Parameter(Mandatory=$true)]
    [string]$AdminKey
)

$env:DB_USER = "football_app"
$env:DB_PASSWORD = $DbPassword
$env:DB_NAME = "football_manager"
$env:ADMIN_KEY = $AdminKey

python app.py
