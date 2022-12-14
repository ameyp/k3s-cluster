{
  secret: {
    // Exports
    new: function(params) {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: params.name,
        namespace: if std.objectHas(params, 'namespace') then params.namespace else "default",
      },
      type: if std.objectHas(params, 'type') then params.type else "Opaque",
      data: if std.objectHas(params, 'data') then params.data else {},
    },
  },
}
