import json

products = {
    "coke": {"price": 250, "amount": 30},
    "fanta": {"price": 250, "amount": 21},
    "sprite": {"price": 250, "amount": 12},
    "lays ": {"price": 150, "amount": 9},
    "doritos": {"price": 150, "amount": 11},
    "oreos": {"price": 150, "amount": 12}
}


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "products ": products
        })
    }
