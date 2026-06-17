.PHONY: build clean

build: node_modules
	node build.mjs

node_modules: package.json
	npm install

clean:
	rm -rf dist
