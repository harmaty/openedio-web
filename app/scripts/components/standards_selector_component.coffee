###

  This components supports selector for groups/categories/standards

  Usage:
  Put in the template a special tag with parameters, for example

  {{standards-selector
			value=value
      parentValue=standard_group
			selectValueText="Select Standard"
			changeValueText="Change Standard"
			startDataLevel=0
			targetDataLevel=2
	}}

  where
  @param value {Object} with id and title fields

###

Openedui.StandardsSelectorComponent = Ember.Component.extend

  open: false
  data: false

  models: [Openedui.StandardGroup, Openedui.Category, Openedui.Standard]

  currentDataLevel: null
  selectedValues: Em.A()

  isLoading: (->
    return !@get('data.isLoaded')
  ).property('data.isLoaded')

  backLink: (->
    @get('currentDataLevel') > @get('startDataLevel')
  ).property('currentDataLevel')

  dialogTitle: ( ->
    dataLevel = @get('currentDataLevel')
    currentValue = @get('selectedValues').objectAt(dataLevel)
    if currentValue then currentValue.get('title') else currentValue = ''
  ).property('currentDataLevel')

  didInsertElement: ->
    # close dialog if clicking outside of the dialog
    Em.$('body').on 'click', =>
      if @get('open') then @closeDialog()

  willDestroyElement: ->
    Em.$('body').off 'click', =>
      if @get('open') then @closeDialog()

  click: (event) ->
    event.stopPropagation()

  loadData:( ->
    dataLevel = @get('currentDataLevel')

    # if we have parentValue - means we accessing not 0 level
    selectedValue = @get('selectedValues').objectAt(dataLevel)
    if selectedValue then id = selectedValue.get('id')

    switch dataLevel
      when 0
        @set 'data', @get('models')[dataLevel].find()

      when 1
        @set 'data', @get('models')[dataLevel].find
          standard_group: id

      when 2
        @set 'data', @get('models')[dataLevel].find
          category: id

      else
        throw new TypeError "Wrong data level, should be in 0-2 range"
  ).observes('currentDataLevel')

  closeDialog: ->
    @set('open', false)

  openDialog: ->
    startDataLevel = @get('startDataLevel')
    @get('selectedValues')[startDataLevel] = @get('parentValue')

    @setProperties
      currentDataLevel: startDataLevel
      open: true

  actions:
    select: ->
      unless @get('open') then @openDialog() else @closeDialog()

    navigationClick: (item) ->
      # check if target data type is equal returned from the nav item
      # and populate event 'nagigationClick' outside of the component
      if item instanceof @get('models')[@get('targetDataLevel')]
        @sendAction('navigationClick', item)
        @toggleProperty('open', true)

      # otherwise digging further in data levels
      else
        # save current item an next data level
        @get('selectedValues')[@get('currentDataLevel') + 1] = item
        @incrementProperty('currentDataLevel')

    back: ->
      @decrementProperty('currentDataLevel')

