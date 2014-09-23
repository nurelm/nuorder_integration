module Integration
  module Builders
    class Order
      def initialize(nuorder_order)
        @nuorder_order = nuorder_order.dup.freeze
      end

      def build
        @order ||= Wombat::Order.new(
          id: @nuorder_order['order_number'],
          nuorder_id: @nuorder_order['_id'],
          status: 'complete',         # TODO: is it always complete?
          channel: 'spree',           # TODO: is it always spree?
          email: 'spree@example.com', # TODO: where to find this email?
          currency: @nuorder_order['currency_code'],
          placed_on: @nuorder_order['created_on'],
          totals: totals,
          rep_name: @nuorder_order['rep_name'], # missing in official wombat docs
          rep_code: @nuorder_order['rep_code'], # missing in official wombat docs
          retailer: retailer,
          line_items: line_items,
          adjustments: adjustments,
          shipping_address: shipping_address,
          billing_address: billing_address,
          payments: payments
        )
      rescue Virtus::CoercionError => e
        raise ArgumentError.new(
          "`#{e.attribute.name}` attribute type is #{e.output.class}, expected #{e.target_type}"
        )
      end

      private

      def totals
        @totals ||= Wombat::OrderTotal.new(
          item: 0,
          adjustment: 0,
          tax: 0,
          shipping: 0,
          payment: 0,
          order: 0
        )
      end

      def retailer
        @retailer ||= Wombat::Retailer.new(
          retailer_name: nuorder_retailer['retailer_name'],
          retailer_code: nuorder_retailer['retailer_code'],
          buyer_name: nuorder_retailer['buyer_name']
        )
      end

      def line_items
        @line_items ||= @nuorder_order['line_items'].map do |line_item|
          Wombat::LineItem.new(
            product_id: 'SPREE T-SHIRT', # TODO: what it should be?
            name: 'Spree t-shirt', # TODO: should we do another api call?
            quantity: 2, # TODO: get quatity from sizes
            price: 100, # TODO: get price from sizes
          )
        end
      end

      def adjustments
        # TODO: placeholders, nuroder does not have tax and shipping info in API
        @adjustments ||= [
          Wombat::Adjustment.new(name: 'Tax', value: 0),
          Wombat::Adjustment.new(name: 'Shipping', value: 0)
        ]
      end

      def shipping_address
        @shipping_address ||= Wombat::Address.new(
          firstname: customers_first_name,
          lastname: customers_last_name,
          address1: nuorder_shipping_address['line_1'],
          address2: nuorder_shipping_address['line_2'],
          zipcode: nuorder_shipping_address['zip'],
          city: nuorder_shipping_address['city'],
          state: nuorder_shipping_address['state'],
          country: 'US', # TODO: there is no country in nuorder
          phone: '0000000' # TODO: there is no phone in nuorder
        )
      end

      def billing_address
        @billing_address ||= Wombat::Address.new(
          firstname: customers_first_name,
          lastname: customers_last_name,
          address1: nuorder_billing_address['line_1'],
          address2: nuorder_billing_address['line_2'],
          zipcode: nuorder_billing_address['zip'],
          city: nuorder_billing_address['city'],
          state: nuorder_billing_address['state'],
          country: 'US', # TODO: there is no country in nuorder
          phone: '0000000' # TODO: there is no phone in nuorder
        )
      end

      def payments
        # TODO: placeholders, nuorder does not have payments in API
        @payments ||= [
          Wombat::Payment.new(
            number: 0,
            status: 'completed',
            amount: 0,
            payment_method: 'Credit card'
          )
        ]
      end

      def split_customers_name
        @nuorder_order.fetch('retailer', {})['buyer_name'].try(:split, ' ', 2)
      end

      def customers_first_name
        split_customers_name.try(:[], 0)
      end

      def customers_last_name
        split_customers_name.try(:[], 1)
      end

      def nuorder_shipping_address
        @nuroder_shipping_address ||= @nuorder_order.fetch('shipping_address', {})
      end

      def nuorder_billing_address
        @nuorder_billing_address ||= @nuorder_order.fetch('billing_address', {})
      end

      def nuorder_retailer
        @nuorder_retailer ||= @nuorder_order.fetch('retailer', {})
      end
    end
  end
end
