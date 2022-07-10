def main (event, context):
	print ("In lambda handler")

	resp = {
		"statusCode": 200,
		"headers": {
			"Access-Control-Allow-Origin": "*",
			"Content-Type": "text/plain"
		},
		"body": "Este es un lambda de prueba"
	}

	return resp