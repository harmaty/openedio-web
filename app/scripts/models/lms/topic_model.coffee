attr = DS.attr

Openedui.Topic = DS.Model.extend
  description: attr('string')
  title: attr('string')
  course: DS.belongsTo('Openedui.Course')
  resources: DS.hasMany('Openedui.Resource')
  standard_idents: attr('array')
  isZeroAssigned: ( ->
    @get('resources.length') == 0
  ).property('resources.@each')

Openedui.Store.registerAdapter 'Openedui.Topic', Openedui.LMSadapter.extend

  findMany: (store, type, ids, owner) ->
    root = this.rootForType(type)
    adapter = this
    ids = this.serializeIds(ids)

    return this.ajax(this.buildURL(root), "GET",
      data:
        course_id: owner.id
    ).then( (json) ->

      adapter.didFindMany(store, type, json)

    ).then(null, error);

    error = (text) ->
      throw new Error text




