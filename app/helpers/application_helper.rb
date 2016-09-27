module ApplicationHelper

  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, lexer: language)
    end
  end

  def markdown(content)
    renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
    options  = {
      autolink:   true,
      no_intra_emphasis: true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(content).html_safe
  end

  def show_username(assign)
    assign.user.try(:username) || "%username%"
  end

  def show_link?(object)
    user_signed_in? && current_user.author_of?(object)
  end

  def views_action(object)
    if user_signed_in? && current_user.author_of?(object)
      render "layouts/views_action", object: object
    end
  end

  def add_icon_to_attachment(f)
    %w(jpg jpeg png gif).any? { |str| f.downcase.include? str } ? "glyphicon glyphicon-picture" : "glyphicon glyphicon-file"
  end

  def login_options
    @redirect_path ? { redirect_to: request.path } : {}
  end

  def count_posts(question)
    count = question.answers.count
    return count < 10 ? "#{count.to_s} Post" : "#{count.to_s} Posts"
  end

  def question_solved?(question)
    question.answers.where(best: true).exists?
  end

  def show_user_status(user)
    user.admin? ? "admin" : "member"
  end

end
