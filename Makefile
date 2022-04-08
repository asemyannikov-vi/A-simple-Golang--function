
SVC_DIR       := $(shell pwd)
GO            := $(shell which go)

LAMBDA_NAME   := main
LAMBDA_DIR    := ${SVC_DIR}/lambdas/${LAMBDA_NAME}

prepare-lambda-package:
	${GO} build ${LAMBDA_DIR}/${LAMBDA_NAME}.go && mv ${SVC_DIR}/${LAMBDA_NAME} ${LAMBDA_DIR}
	zip ${LAMBDA_DIR}/${LAMBDA_NAME}.zip -j ${LAMBDA_DIR}/${LAMBDA_NAME}

launch-lambda-with-sam:
	sam build --template-file ${LAMBDA_DIR}/template.yaml
	sam local start-api