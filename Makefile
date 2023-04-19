unit-test: generate-resources generate-policies
	kyverno test ./

generate-resources:
	./Tools/scripts/generateResources.sh

generate-policies: build-lula
	./Tools/scripts/generatePolicies.sh
	
build-lula:
	cd Tools/lula && make build

lint: yaml-lint helm-lint terraform-lint

yaml-lint:
	yamllint .

helm-lint:
	Tools/scripts/lintHelm.sh

terraform-lint:
	tflint --recursive
	terraform fmt -recursive -check -diff

bats-test:
	./bats/bats-core/bin/bats --jobs 4 -r ./AWS

bats-quick-test:
	./bats/bats-core/bin/bats -r --filter-tags "!speed:slow" --jobs 4 ./AWS 