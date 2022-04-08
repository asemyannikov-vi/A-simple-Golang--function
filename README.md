# How to launch a λ-function?

To launch a __λ-function__ from the current repo, first prepare a __λ-package__ by typing
```
make prepare-lambda-package
```
and then run the __λ-function__ with __SAM__
```
make launch-lambda-with-sam
```

In order to make sure that everything is working correctly, you need to send an HTTP request using `curl` and get a response from the __λ-function__
```
curl http://127.0.0.1:3000/

Hello from λ!
```

Please, read more about Golang __λ-function__ in [this artical](https://teletype.in/@alexander.semyannikov/golang-lambda-function).