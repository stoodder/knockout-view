isObject = (object) -> ( typeof object == typeof {} );
defer = (callback) -> setTimeout(callback,1)

#Add a knockout binding for views
ko.bindingHandlers["view"] = ( ->

	makeTemplateValueAccessor = (viewModel) ->
		() ->
			return {
				'if': viewModel
				'data': viewModel
				'templateEngine': ko.nativeTemplateEngine.instance
			}

	'init': (element, valueAccessor) ->
		value = valueAccessor()
		value = {} unless isObject value

		viewModel = ko.utils.unwrapObservable(value.viewModel)

		ko.bindingHandlers['template']['init'](
			element,
			makeTemplateValueAccessor(viewModel)
		)

	'update': (element, valueAccessor, args...) ->
		value = valueAccessor()
		value = {} unless isObject value

		return if not value.template?
		return if not value.viewModel?

		return if ko.utils.domData.get(element, '__ko_view_updating__') is true
		ko.utils.domData.set(element, '__ko_view_updating__', true)

		defer ->
			template = ko.utils.unwrapObservable(value.template)
			execScripts = !!ko.utils.unwrapObservable(value.execScripts)

			if not template?
				$(element).html("")
			else
				originalTemplate = ko.utils.domData.get(element, '__ko_anon_template__')
				ko.utils.domData.set(element, '__ko_anon_template__', template)

				ko.bindingHandlers['template']['update'](
					element,
					makeTemplateValueAccessor(value.viewModel),
					args...
				)

				if template isnt originalTemplate and execScripts is true
					$(element).find("script").each( (index, script) ->
						script = $(script)
						eval( script.text() ) if script.attr('type').toLowerCase() is "text/javascript"
					)
				#END if template updated
			#END if not template?

			ko.utils.domData.set(element, '__ko_view_updating__', false)
		#END defer
)()