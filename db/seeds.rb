@user = User.where(email: "yoda@dagobah.com").first

if @user.nil?
  @user      = User.create(email: "yoda@dagobah.com", first: "Yoda", last: "the Great One", password: "foobar16")
  @workspace = Workspace.create(name: "The first workspace")
  @uwc       = Collaboratorship.create(collaborator: @user, collaboratable: @workspace)
  @project   = Project.create(title: "The first project", description: "A very good project", workspace: @workspace)
  @upc       = Collaboratorship.create(collaborator: @user, collaboratable: @project)
end
