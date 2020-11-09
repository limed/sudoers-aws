locals {

  lifecycle_rule = [
    {
      id      = "archive-to-glacier"
      enabled = true

      transition = [
        {
          days          = "90"
          storage_class = "GLACIER"
        }
      ]
    }
  ]

}
