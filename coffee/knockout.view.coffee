isObject = (object) -> ( typeof object == typeof {} );
isFunction = (object) -> Object::toString.call( object ) is "[object Function]"
isArray = (object) -> Object::toString.call( object ) is "[object Array]"
isString = (object) -> Object::toString.call( object ) is "[object String]"
trim = (str) -> str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')
leftTrim = (str) -> str.replace(/^\s+/,'')
rightTrim = (str) -> str.replace(/\s+$/,'')
startsWith = (haystack, needle) -> haystack.indexOf(needle) is 0
endsWith = (haystack, needle) ->  haystack.indexOf(needle, haystack.length - needle.length) isnt -1
unwrap = (val) -> if isFunction val then val() else val
#unwrap = ko.utils.unwrapObservable
#Add a knockout binding for views
ko.bindingHandlers["view"] = (() ->
	templates = {}

	makeTemplateValueAccessor = (valueAccessor) ->
		() ->
			value = unwrap valueAccessor
			return {
				'if': value
				'data': value
				'templateEngine': ko.nativeTemplateEngine.instance
			}
	
	'init': (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		value = unwrap valueAccessor
		value = {} unless isObject value
		value.template ?= null
		value.viewModel ?= null

		ko.bindingHandlers['template']['init'](
			element, 
			makeTemplateValueAccessor(value.viewModel)
		)
	
	'update': (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		value = unwrap valueAccessor
		value = {} unless isObject value
		value.template ?= null
		value.viewModel ?= null

		return if value.template is null
		return if value.viewModel is null

		template = unwrap(value.template)
		
		if not template?
			$(element).html("")
		else
			if templates[template]?
				ko.utils.domData.set(element, '__ko_anon_template__', templates[template])
				ko.bindingHandlers['template']['update'](
					element, 
					makeTemplateValueAccessor(value.viewModel), 
					allBindingsAccessor, 
					viewModel, 
					bindingContext
				)
			
			else if startsWith(template, '#')
				templates[template] = $(template).html()

				ko.utils.domData.set(element, '__ko_anon_template__', templates[template])
				ko.bindingHandlers['template']['update'](
					element, 
					makeTemplateValueAccessor(value.viewModel), 
					allBindingsAccessor, 
					viewModel, 
					bindingContext
				)
			else
				$.get( 
					template, 
					(data) -> 
						templates[template] = data
						
						ko.utils.domData.set(element, '__ko_anon_template__', templates[template])
						ko.bindingHandlers['template']['update'](
							element, 
							makeTemplateValueAccessor(value.viewModel), 
							allBindingsAccessor, 
							viewModel, 
							bindingContext
						)
				)
)()