.PHONY: test clean

# install: package
#
package: venv package_get_index package_get_item package_post_item package_layer

package_get_index:
	. ./target/venv/bin/activate; \
	pip install -r get/index/requirements.txt -t target/package
	cp get/index/*.py target/package/
	(cd target/package && zip -r ../get_index.zip .)
	
package_get_item:
	. ./target/venv/bin/activate; \
	pip install -r get/item/requirements.txt -t target/package
	cp get/item/*.py target/package/
	(cd target/package && zip -r ../get_item.zip .)

package_post_item:
	. ./target/venv/bin/activate; \
	pip install -r post/item/requirements.txt -t target/package
	cp post/item/*.py target/package/
	(cd target/package && zip -r ../post_item.zip .)

package_layer:
	. ./target/venv/bin/activate; \
	pip install -r layer/requirements.txt -t target/package/python
	#cp post/item/*.py target/package/
	(cd target/package && zip -r ../layer.zip .)

clean:
	rm -rf venv package

venv:
	python3.7 -m venv target/venv
