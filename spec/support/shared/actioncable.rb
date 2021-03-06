shared_examples "perform job after commit" do
  it "tests after commit hook" do
    expect(job).to receive(:perform_later).with(subject)
    subject.save!
  end
end
