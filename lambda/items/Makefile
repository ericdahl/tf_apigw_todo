.PHONY: test clean

install: venv
	. ./target/venv/bin/activate; \
	pip install -r get/requirements.txt -t target/package
	cp get/*.py target/package/
	(cd target/package && zip -r ../get.zip .)

clean:
	rm -rf venv package

venv: get/requirements.txt
	python3.7 -m venv target/venv
