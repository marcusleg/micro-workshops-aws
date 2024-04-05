import json

def handler(event, context):
    # Parse the input event as JSON
    # event is assumed to be a dictionary with 'username' and 'password'
    username = event.get('username')
    password = event.get('password')

    # Check if the password is at least 12 characters long
    if password and len(password) >= 12:
        response = {
            'passwordValid': True,
        }
    else:
        response = {
            'passwordValid': False,
            'passwordError': 'Password must be at least 12 characters long.'
        }

    return response
