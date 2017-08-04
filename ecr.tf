resource "aws_ecr_repository" "repo-php" {
	name = "fubra/demo-php"
}

resource "aws_ecr_repository" "repo-http" {
	name = "fubra/demo-http"
}

resource "aws_ecr_repository_policy" "repo-php" {
	repository = "${aws_ecr_repository.repo-php.id}"
	policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new statement",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "repo-http" {
	repository = "${aws_ecr_repository.repo-http.id}"
	policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new statement",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}
