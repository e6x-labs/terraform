resource "aws_s3_bucket" "my_protected_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

resource "null_resource" "waiting" {
  provisioner "local-exec" {
    command = "sleep 10"
  }

  triggers = {
    bucket = aws_s3_bucket.my_protected_bucket.bucket
  }

  depends_on = [aws_s3_bucket.my_protected_bucket]
}

resource "aws_s3_bucket_versioning" "my_protected_bucket_versioning" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.my_protected_bucket, null_resource.waiting]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_protected_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.my_protected_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }

  depends_on = [aws_s3_bucket.my_protected_bucket, null_resource.waiting]
}

resource "aws_s3_bucket_public_access_block" "my_protected_bucket_access" {
  bucket = aws_s3_bucket.my_protected_bucket.id

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.my_protected_bucket, null_resource.waiting]
}

resource "aws_s3_bucket_logging" "my_protected_bucket_logging" {
  bucket = aws_s3_bucket.my_protected_bucket.id

  target_bucket = aws_s3_bucket.my_protected_bucket.id
  target_prefix = "bucket-logs/"
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.my_protected_bucket, null_resource.waiting]
}


resource "aws_s3_bucket_acl" "my_protected_bucket_acl" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership, null_resource.waiting]
}

resource "aws_s3_bucket_lifecycle_configuration" "delete_cached_results_lifecycle_rule" {
  rule {
    id     = "ExpirecacheObjects"
    status = "Enabled"
    filter {
      prefix = "cached-query-results/"
    }

    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    id     = "DeleteExpiredDeleteMarkers"
    status = "Enabled"

    filter {
      prefix = "cached-query-results/"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  bucket = aws_s3_bucket.my_protected_bucket.id

  depends_on = [aws_s3_bucket.my_protected_bucket, null_resource.waiting]

}
