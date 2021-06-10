.PHONY: test clean

package: lambda target/layer.zip

target/layer.zip: layer/requirements.txt
	python3.7 -m venv target/venv_layer
	. ./target/venv_layer/bin/activate; \
	pip install -r layer/requirements.txt -t target/package_layer/python
	(cd target/package_layer && zip -r ../layer.zip .)

lambda: target/post/item.zip target/delete/item.zip target/get/item.zip target/get/index.zip

target/%.zip : %/*.py
	mkdir -p $(dir $@)
	zip -j -r $@ $^

clean:
	rm -rf venv package target

venv:
	python3.7 -m venv target/venv
