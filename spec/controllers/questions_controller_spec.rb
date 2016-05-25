require "rails_helper"
require "rails-controller-testing"

RSpec.describe QuestionsController do
  sign_in_user
  let(:question) { create(:question, user: @user) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 2) }
    before { get :index }

    it "populates an array all questions" do
      expect(assigns(:questions)).to eq questions
    end

    it "render index view" do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it "assigns the requested question to @question" do
      expect(assigns(:question)).to eq question
    end

    it "assign new Attachment to @answer" do
      expect(assigns(:answer).attachments.first).to be_a_new(Attachment)
    end

    it "render show view" do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { get :new }

    it "assign new Question to @question" do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it "assign new Attachment to @question" do
      expect(assigns(:question).attachments.first).to be_a_new(Attachment)
    end

    it "render new view" do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: question } }

    it "assigns the requested question to @question" do
      expect(assigns(:question)).to eq question
    end

    it "render edit view" do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context "With valide attributes" do
      it "saves the new questions in the database and assignes to current user" do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(@user.questions, :count).by(1)
      end

      it "redirect to show view" do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to question_path(assigns(:question))
      end
    end

    context "with invalid attributes" do
      it "does not save the question" do
        expect { post :create, params: { question: attributes_for(:invalid_question) } }.to_not change(Question, :count)
      end

      it "re-render new view" do
        post :create, params: { question: attributes_for(:invalid_question) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context "With valide attributes" do
      it "assigns the requested attributes to @question" do
        patch :update, params: { id: question, question:  attributes_for(:question) }
        expect(assigns(:question)).to eq question
      end

      it "change question attributes" do
        patch :update, params: { id: question, question: { title: "new title", body: "new body" } }
        question.reload
        expect(question.title).to eq "new title"
        expect(question.body).to eq "new body"
      end

      it "redirect to updated question" do
        patch :update, params: { id: question, question: attributes_for(:question) }
        expect(response).to redirect_to question_path(assigns(:question))
      end
    end

    context "invalid attributes" do
      before { patch :update, params: { id: question, question: { title: "new title", body: nil } } }
      it "does not change question attributes" do
        question.reload
        expect(question.title).to eq question.title
        expect(question.body).to eq question.body
      end

      it "re-render edit view" do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    before { question }
    context "Author" do
      it "deletes question" do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end

      it "redirect to index view" do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_url
      end
    end

    context "Non-author" do
      it "deletes question" do
        new_question = create(:question, user: create(:user))
        expect { delete :destroy, params: { id: new_question } }.to_not change(Question, :count)
      end

      it "redirect to index view" do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_url
      end
    end
  end
end
