
build: components lib/YouAreDaChef.js
	@component build --dev

lib/YouAreDaChef.js: lib/YouAreDaChef.coffee
	@coffee -c $<

components: component.json
	@component install --dev

clean:
	rm -fr build components

.PHONY: clean
