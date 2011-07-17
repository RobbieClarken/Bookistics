class BooksController < ApplicationController
  before_filter :require_user, :only => [ :new, :create, :edit, :update, :lookup_books ]

  def new
  end

  def lookup_books
    @books = AmazonBook.find(params[:keywords])
  end

  def create
    asin = params[:id]

    unless asin.nil?
      book = Book.find_by_asin(asin)

      unless book.nil?
        add_book_to_current_user(book) unless current_user.has_book? book.asin
      else
        amazon_book = AmazonBook.find_by_asin(asin)

        add_book_to_current_user(Book.new(amazon_book.attributes)) unless amazon_book.nil?
      end
    end

    render :nothing => true
  end

  def edit
    asin = params[:id]

    if current_user.has_book?(asin)
      @book = Book.find_by_asin(asin)
      @log = current_user.find_log(asin)
    end
  end

  def update
    if current_user.has_book?(params[:id])
      log = current_user.find_log(params[:id])

      log.start_date = params[:start_date]
      log.finish_date = params[:finish_date]

      log.save!
    end

    redirect_to edit_book_path(params[:id])
  end

  private

  def add_book_to_current_user (book)
    unless current_user.nil?
      current_user.books << book
      current_user.save!
    end
  end
end