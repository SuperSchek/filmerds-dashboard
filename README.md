# Direct S3 Upload Example

[![Build Status](https://travis-ci.org/danielwestendorf/direct-s3-upload-example.svg?branch=master)](https://travis-ci.org/danielwestendorf/direct-s3-upload-example)

An opinionated starting point for do-it-yourself AWS S3 file uploads. Example in Rails, but could easily be implemented in any other Ruby based web app.

## Fire up your engines!

```sh
$ bundle install
```

```sh
export AWS_ACCESS_KEY_ID=KEY
export AWS_SECRET_ACCESS_KEY=SECRET
export AWS_S3_BUCKET=BUCKET_NAME
export AWS_REGION=REGION
```

```sh
rails db:migrate
```

```sh
rake test
```

```sh
rails s
```

Visit http://localhost:3000/uploads/new and upload!
