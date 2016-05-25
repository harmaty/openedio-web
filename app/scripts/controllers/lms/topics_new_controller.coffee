###

  This controller supports creation of new topic in LMS

###
Openedui.TopicsNewController = Ember.ArrayController.extend
  needs: ["course", "topic"]

  # TODO not DRY with topic controller
  standardGroup:( ->
    @get('controllers.course.standard_group')
  ).property('controllers.course.standard_group')

  displayingStandard: ( ->
    #TODO support multiple standards
    {title: @get('standard_idents')[0]}
  ).property('standard_idents.@each')

  actions:
    createRecord: (topic) ->
      # dont go further if title is empty
      if @get('title')
        return if @get('isLoading')
        # set isLoading state in order to set disabled state on the button
        @set('isLoading', true)
        course = @get("controllers.course.content")

        topic = Openedui.Topic.createRecord
          title: @get("title")
          description: @get("description")
          course: course
          standard_idents: @get('standard_idents')

        @get('store').commit()

        topic.one 'didCreate', =>
          #hacking around ember-data issue
          #https://github.com/emberjs/data/issues/405#issuecomment-18726035
          Ember.run.next =>
            course.reload()
            @transitionToRoute('topic', topic.get('id'))

      else
        @set "errorMessage", "Topic Name can't be blank"

    selectStandard: (standard) ->
      @get('controllers.topic').selectStandardMethod.call(this, standard)