class TransactionsController < ApplicationController
  before_action :init_transaction, only: [:new, :new_large, :new_extra_large]

  PER_PAGE = 20

  def index
    @transactions = Transaction.page(params[:page]).per(PER_PAGE).includes(:manager)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    @manager = get_manager
    render "new_#{params[:type]}"
  end

  def new_large
  end

  def new_extra_large
    @manager = get_manager
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      redirect_to @transaction
    else
      @manager = get_manager if params[:type] == 'extra'
      render "new_#{params[:type]}"
    end
  end

  private
  def init_transaction
    @transaction = Transaction.new
  end

  def get_manager
    @manager = Manager.find(Manager.ids.sample)
  end

  def transaction_params
    params.require(:transaction).permit(
      :manager_id,
      :first_name,
      :last_name,
      :from_amount,
      :from_currency,
      :to_currency
    )
  end
end
