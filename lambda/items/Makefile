.PHONY: test clean

# install: package
#
package: target/get_index.zip target/get_item.zip target/post_item.zip target/layer.zip

target/get_index.zip: get/item/main.py
	python3.7 -m venv target/venv_get_index
	. ./target/venv_get_index/bin/activate; \
	pip install -r get/index/requirements.txt -t target/package_get_index
	cp get/index/*.py target/package_get_index/
	(cd target/package_get_index && zip -r ../get_index.zip .)
	
target/get_item.zip: get/item/main.py
	python3.7 -m venv target/venv_get_item
	. ./target/venv_get_item/bin/activate; \
	pip install -r get/item/requirements.txt -t target/package_get_item
	cp get/item/*.py target/package_get_item/
	(cd target/package_get_item && zip -r ../get_item.zip .)

target/post_item.zip: post/item/main.py
	python3.7 -m venv target/venv_post_item
	. ./target/venv_post_item/bin/activate; \
	pip install -r post/item/requirements.txt -t target/package_post_item
	cp post/item/*.py target/package_post_item/
	(cd target/package_post_item && zip -r ../post_item.zip .)

target/layer.zip: layer/requirements.txt
	python3.7 -m venv target/venv_layer
	. ./target/venv_layer/bin/activate; \
	pip install -r layer/requirements.txt -t target/package_layer/python
	(cd target/package_layer && zip -r ../layer.zip .)

clean:
	rm -rf venv package target

venv:
	python3.7 -m venv target/venv
