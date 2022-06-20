locals {
  resource_path = "./resources"

  lambda = {
    path    = "${local.resource_path}/lambda"
    runtime = "python3.9"

    functions = {
      testDB = {
        filename      = "db_test.zip"
        handler       = "db_test.main_handler"
        api_call      = "dbtest"
        method        = "GET"
        authorization = "NONE"
      }
    }

  }

  s3 = {
    main_website = {
      bucket_name = "cloud-vending-machine"
      tier        = "STANDARD"
      path        = "./resources/main_website"

      index_document = "index.html"
      error_document = "html/error.html"
    }

    stock_website = {
      bucket_name = "cloud-vending-machine-stock"
      tier        = "STANDARD"
      path        = "./resources/stock_website"

      index_document = "index.html"
      error_document = "error.html"
    }
  }

  cloudfront = {
    lambda_edge = {
      filename = "${local.resource_path}/lambda_edge/rewrite_uri.zip"
      function_name = "LambdaEdge-RewriteUri"
      handler = "rewrite_uri.handler"
    }
  }
}