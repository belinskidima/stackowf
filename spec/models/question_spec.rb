require "rails_helper"

RSpec.describe Question do
  it { should validate_presence_of :title }
  it { should validate_presence_of :body }
  it { should belong_to :user }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:destroy) }
end
