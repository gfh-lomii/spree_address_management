# https://github.com/spree-contrib/spree_address_book/blob/master/app/helpers/spree/addresses_helper.rb
module Spree
  module Admin
    module AddressesHelper
      def address_field(form, method, address_id = 'b', &handler)
        content_tag :div, id: [address_id, method].join, class: 'form-group checkout-content-inner-field has-float-label' do
          if handler
            yield
          else
            is_required = Spree::Address.required_fields.include?(method)
            method_name = I18n.t("activerecord.attributes.spree/address.#{method}")
            required = Spree.t(:required)
            form.text_field(method,
                            class: [is_required ? 'required' : nil, 'spree-flat-input'].compact,
                            required: is_required,
                            placeholder: is_required ? "#{method_name} #{required}" : method_name,
                            aria: { label: method_name }) +
              form.label(method_name,
                         is_required ? "#{method_name} #{required}" : method_name,
                         class: 'text-uppercase')
          end
        end
      end

      def address_zipcode(form, country, address_id = 'b')
        country ||= Spree::Country.default
        is_required = country.zipcode_required?
        method_name = Spree.t(:zipcode)
        required = Spree.t(:required)
        form.text_field(:zipcode,
                        class: [is_required ? 'required' : nil, 'spree-flat-input'].compact,
                        required: is_required,
                        placeholder: is_required ? "#{method_name} #{required}" : method_name,
                        aria: { label: Spree.t(:zipcode) }) +
          form.label(:zipcode,
                     is_required ? "#{method_name} #{required}" : method_name,
                     class: 'text-uppercase',
                     id: address_id + '_zipcode_label')
      end

      def address_state(form, country, address_id = 'b')
        country ||= Spree::Country.find(Spree::Config[:default_country_id])
        have_states = country.states.any?
        state_elements = [
          form.collection_select(:state_id, country.states.order(:name),
                                :id, :name,
                                 { prompt: Spree.t(:state) },
                                 class: [have_states ? 'required' : 'hidden', 'spree-flat-select'].compact,
                                 aria: { label: Spree.t(:state) },
                                 disabled: !have_states) +
            form.text_field(:state_name,
                            class: [!have_states ? 'required' : 'hidden', 'spree-flat-input'].compact,
                            aria: { label: Spree.t(:state) },
                            disabled: have_states,
                            placeholder: Spree.t(:state) + " #{Spree.t(:required)}") +
            form.label(Spree.t(:state).downcase,
                       raw(Spree.t(:state) + content_tag(:abbr, " #{Spree.t(:required)}")),
                       class: [have_states ? 'state-select-label' : nil, ' text-uppercase'].compact,
                       id: address_id + '_state_label') +
            image_tag('arrow.svg',
                      class: [!have_states ? 'hidden' : nil, 'position-absolute spree-flat-select-arrow'].compact)
        ].join.tr('"', "'").delete("\n")

        content_tag(:noscript, form.text_field(:state_name, class: 'required')) +
          javascript_tag("document.write(\"<span class='d-block position-relative'>#{state_elements.html_safe}</span>\");")
      end

      def user_available_addresses
        return unless try_spree_current_user

        try_spree_current_user.addresses.where(country: available_countries)
      end
    end
  end
end
