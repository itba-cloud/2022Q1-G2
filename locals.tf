locals {

  availability_zone_names = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)

  resource_path = "./resources"

  lambda = {
    path    = "${local.resource_path}/lambda"
    runtime = "python3.9"

    functions = {
      getProducts = {
        filename      = "buyProduct.zip"
        handler       = "buyProduct.handler"
        api_call      = "buyProduct"
        method        = "GET"
        authorization = "NONE"
      },
      buyProduct = {
        filename      = "getProducts.zip"
        handler       = "getProducts.handler"
        api_call      = "getProducts"
        method        = "GET"
        authorization = "NONE"
      },
      modifyStock = {
        filename      = "modifyStock.zip"
        handler       = "modifyStock.handler"
        api_call      = "modifyStock"
        method        = "GET"
        authorization = "NONE"
      }
    }
  }

  s3 = {
    main_website = {
      bucket_name = "cloud-vending-machine-123"
      tier        = "STANDARD"
      path        = "./resources/main_website"

      index_document = "index.html"
      error_document = "html/error.html"
    }

    stock_website = {
      bucket_name = "cloud-vending-machine-stock-123"
      tier        = "STANDARD"
      path        = "./resources/stock_website"

      index_document = "index.html"
      error_document = "error.html"
    }
  }

  cloudfront = {
    lambda_edge = {
      filename      = "${local.resource_path}/lambda_edge/rewrite_uri.zip"
      function_name = "LambdaEdge-RewriteUri"
      handler       = "rewrite_uri.handler"
    }
  }
}