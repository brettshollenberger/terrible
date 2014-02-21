require 'spec_helper'

describe Project do
  let(:project) { FactoryGirl.create(:project) }

  describe "Validations" do
    it "is valid" do
      expect(project).to be_valid
    end

    it "is invalid without a title" do
      project.title = nil
      expect(project).to_not be_valid
    end
  end
end
