init:
	mkdir -p reports

run_script:
	artillery run test_scripts/$(script).yml

load_test: init
	artillery run test_scripts/poller.yml -o reports/poller.json &
	artillery run test_scripts/artifact-info.yml -o reports/artifact-info.json &
	artillery run test_scripts/downloads.yml -o reports/downloads.json &

report:
	artillery report reports/$(script).json

generate_payload:
	bundle exec ruby payloads/generators/$(script).rb

.PHONY: init run_script load_test generate_payload
