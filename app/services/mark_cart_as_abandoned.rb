class MarkCartAsAbandoned
  class << self
    def call
      Cart.all_abandoned.each { |cart| cart.abandoned! }
      Cart.old_abandoned.destroy_all
    end
  end
end
