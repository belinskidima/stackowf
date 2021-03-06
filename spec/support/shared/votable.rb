shared_examples 'votable' do
  let(:user) { create(:user) }
  let(:vote_up) { post :vote_up, params: { id: votable }, format: :js }
  let(:vote_down) { post :vote_down, params: { id: votable }, format: :js }

  describe "#POST Vote" do
    sign_in_user

    context "Vote up/down/cancel if user is not author of votable" do
      it "create vote with score is 1" do
        vote_up
        expect(votable.votes.first.score).to eq 1
      end

      it "create vote with score is -1" do
        vote_down
        expect(votable.votes.first.score).to eq -1
      end

      it "render json with votable id and rating" do
        vote_up
        expect(response.body).to eq ({ id: votable.id, score: votable.vote_score, voted: "up", resource: votable.resource }).to_json
        vote_down
        expect(response.body).to eq ({ id: votable.id, score: votable.vote_score, voted: "down", resource: votable.resource }).to_json
      end
    end

    context "Cancel vote up/down if user is not author of votable" do
      let(:voteup) { create(:vote, score: 1, votable: votable, user: @user) }
      let(:votedown) { create(:vote, score: -1, votable: votable, user: @user) }

      it "Cancel vote if vote is up" do
        voteup.reload
        vote_up
        expect(votable.votes.count).to eq 0
      end

      it "render json with votable id and rating" do
        voteup.reload
        vote_up
        expect(response.body).to eq ({ id: votable.id, score: votable.vote_score, voted: "none", resource: votable.resource }).to_json
      end

      it "Cancel vote if vote is down" do
        votedown.reload
        vote_down
        expect(votable.votes.count).to eq 0
      end

      it "render json with votable id and rating" do
        votedown.reload
        vote_down
        expect(response.body).to eq ({ id: votable.id, score: votable.vote_score, voted: "none", resource: votable.resource }).to_json
      end

    end

    context "if user is author of votable" do
      before { sign_in user }
      it "doesn't create vote up" do
        vote_up
        expect(votable.votes.count).to eq 0
      end

      it "doesn't create vote down" do
        vote_down
        expect(votable.votes.count).to eq 0
      end

      it "render nothing with status 403" do
        vote_up
        expect(response.body).to eq ""
        expect(response.status).to eq 403
        vote_down
        expect(response.body).to eq ""
        expect(response.status).to eq 403
      end
    end
  end
end
