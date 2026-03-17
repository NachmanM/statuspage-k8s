import os

#
# Required Settings
#

# This is a list of valid fully-qualified domain names (FQDNs) for the Status-Page server. Status-Page will not permit
# write access to the server via any other hostnames. The first FQDN in the list will be treated as the preferred name.
#
# Example: ALLOWED_HOSTS = ['status-page.example.com', 'status-page.internal.local']
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '*').split(',')

# PostgreSQL database configuration. See the Django documentation for a complete list of available parameters:
#   https://docs.djangoproject.com/en/stable/ref/settings/#databases
DATABASE = {
    'NAME': os.environ.get('DB_NAME', 'status-page'),        # Database name
    'USER': os.environ.get('DB_USER', 'statuspage'),         # PostgreSQL username
    'PASSWORD': os.environ.get('DB_PASSWORD', 'statuspage'), # PostgreSQL password
    'HOST': os.environ.get('DB_HOST', 'localhost'),          # Database server
    'PORT': os.environ.get('DB_PORT', '5432'),               # Database port (leave blank for default)
    'CONN_MAX_AGE': int(os.environ.get('DB_CONN_MAX_AGE', 300)), # Max database connection age
}

# Redis database settings. Redis is used for caching and for queuing background tasks. A separate configuration exists
# for each. Full connection details are required.
REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))
REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD', '')

REDIS = {
    'tasks': {
        'HOST': REDIS_HOST,
        'PORT': REDIS_PORT,
        # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
        # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
        # 'SENTINEL_SERVICE': 'status-page',
        'PASSWORD': REDIS_PASSWORD,
        'DATABASE': int(os.environ.get('REDIS_TASKS_DB', 0)),
        'SSL': os.environ.get('REDIS_SSL', 'False').lower() == 'true',
        # Set this to True to skip TLS certificate verification
        # This can expose the connection to attacks, be careful
        # 'INSECURE_SKIP_TLS_VERIFY': False,
    },
    'caching': {
        'HOST': REDIS_HOST,
        'PORT': REDIS_PORT,
        # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
        # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
        # 'SENTINEL_SERVICE': 'statuspage',
        'PASSWORD': REDIS_PASSWORD,
        'DATABASE': int(os.environ.get('REDIS_CACHE_DB', 1)),
        'SSL': os.environ.get('REDIS_SSL', 'False').lower() == 'true',
        # Set this to True to skip TLS certificate verification
        # This can expose the connection to attacks, be careful
        # 'INSECURE_SKIP_TLS_VERIFY': False,
    }
}

# Define the URL which will be used e.g. in E-Mails
SITE_URL = os.environ.get('SITE_URL', '')

# This key is used for secure generation of random numbers and strings. It must never be exposed outside of this file.
# For optimal security, SECRET_KEY should be at least 50 characters in length and contain a mix of letters, numbers, and
# symbols. Status-Page will not run without this defined. For more information, see
# https://docs.djangoproject.com/en/stable/ref/settings/#std:setting-SECRET_KEY
SECRET_KEY = os.environ.get('SECRET_KEY', 'insecure-default-key-change-in-production')

#
# Optional Settings
#

# Specify one or more name and email address tuples representing Status-Page administrators. These people will be notified of
# application errors (assuming correct email settings are provided).
ADMINS = [
    # ('John Doe', 'jdoe@example.com'),
]

# Enable any desired validators for local account passwords below. For a list of included validators, please see the
# Django documentation at https://docs.djangoproject.com/en/stable/topics/auth/passwords/#password-validation.
AUTH_PASSWORD_VALIDATORS = [
    # {
    #     'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    #     'OPTIONS': {
    #         'min_length': 10,
    #     }
    # },
]

# Base URL path if accessing Status-Page within a directory. For example, if installed at
# https://example.com/status-page/, set: BASE_PATH = 'status-page/'
BASE_PATH = os.environ.get('BASE_PATH', '')

# API Cross-Origin Resource Sharing (CORS) settings. If CORS_ORIGIN_ALLOW_ALL is set to True, all origins will be
# allowed. Otherwise, define a list of allowed origins using either CORS_ORIGIN_WHITELIST or
# CORS_ORIGIN_REGEX_WHITELIST. For more information, see https://github.com/ottoyiu/django-cors-headers
CORS_ORIGIN_ALLOW_ALL = os.environ.get('CORS_ORIGIN_ALLOW_ALL', 'False').lower() == 'true'
CORS_ORIGIN_WHITELIST = [
    # 'https://hostname.example.com',
]
CORS_ORIGIN_REGEX_WHITELIST = [
    # r'^(https?://)?(\w+\.)?example\.com$',
]

# Set to True to enable server debugging. WARNING: Debugging introduces a substantial performance penalty and may reveal
# sensitive information about your installation. Only enable debugging while performing testing. Never enable debugging
# on a production system.
DEBUG = os.environ.get('DEBUG', 'False').lower() == 'true'

# Email settings
EMAIL = {
    'SERVER': os.environ.get('EMAIL_SERVER', 'localhost'),
    'PORT': int(os.environ.get('EMAIL_PORT', 25)),
    'USERNAME': os.environ.get('EMAIL_USERNAME', ''),
    'PASSWORD': os.environ.get('EMAIL_PASSWORD', ''),
    'USE_SSL': os.environ.get('EMAIL_USE_SSL', 'False').lower() == 'true',
    'USE_TLS': os.environ.get('EMAIL_USE_TLS', 'False').lower() == 'true',
    'TIMEOUT': int(os.environ.get('EMAIL_TIMEOUT', 10)),  # seconds
    'FROM_EMAIL': os.environ.get('EMAIL_FROM', ''),
    'SUBJECT_PREFIX': os.environ.get('EMAIL_SUBJECT_PREFIX', '[Status-Page] '),
}

# IP addresses recognized as internal to the system. The debugging toolbar will be available only to clients accessing
# Status-Page from an internal IP.
INTERNAL_IPS = ('127.0.0.1', '::1')

# Enable custom logging. Please see the Django documentation for detailed guidance on configuring custom logs:
#   https://docs.djangoproject.com/en/stable/topics/logging/
LOGGING = {}

# The length of time (in seconds) for which a user will remain logged into the web UI before being prompted to
# re-authenticate. (Default: 1209600 [14 days])
LOGIN_TIMEOUT = None

# The file path where uploaded media such as image attachments are stored. A trailing slash is not needed. Note that
# the default value of this setting is derived from the installed location.
# MEDIA_ROOT = '/opt/status-page/statuspage/media'

# Overwrite Field Choices for specific Models (Note that this may break functionality!
# Please check the docs, before overwriting any choices.
FIELD_CHOICES = {}

PLUGINS = [
    # 'sp_uptimerobot',  # Built-In Plugin for UptimeRobot integration
    # 'sp_external_status_providers',  # Built-In Plugin for integrating external Status Pages
]

# Plugins configuration settings. These settings are used by various plugins that the user may have installed.
# Each key in the dictionary is the name of an installed plugin and its value is a dictionary of settings.
PLUGINS_CONFIG = {
    'sp_uptimerobot': {
        'uptime_robot_api_key': os.environ.get('UPTIME_ROBOT_API_KEY', ''),
    },
}

# Maximum execution time for background tasks, in seconds.
RQ_DEFAULT_TIMEOUT = int(os.environ.get('RQ_DEFAULT_TIMEOUT', 300))

# The name to use for the csrf token cookie.
CSRF_COOKIE_NAME = 'csrftoken'

# The name to use for the session cookie.
SESSION_COOKIE_NAME = 'sessionid'

# Time zone (default: UTC)
TIME_ZONE = os.environ.get('TIME_ZONE', 'UTC')

# Date/time formatting. See the following link for supported formats:
# https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
DATE_FORMAT = 'N j, Y'
SHORT_DATE_FORMAT = 'Y-m-d'
TIME_FORMAT = 'g:i a'
SHORT_TIME_FORMAT = 'H:i:s'
DATETIME_FORMAT = 'N j, Y g:i a'
SHORT_DATETIME_FORMAT = 'Y-m-d H:i'