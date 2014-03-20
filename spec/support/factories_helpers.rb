module FactoriesHelpers
  def workspace_for_user(user)
    @uwc = FactoryGirl.create(:user_workspace_collaboration, collaborator: user)
    @uwc.collaboratable
  end

  def project_in_workspace(workspace)
    @project = FactoryGirl.create(:project, 
                                  title: "Workspaced Project",
                                  workspace: workspace)

    workspace.users.each do |user|
      FactoryGirl.create(:user_project_collaboration, 
                         collaborator: user,
                         collaboratable: @project)
    end

    @project
  end
end
