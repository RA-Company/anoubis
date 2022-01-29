require "anoubis/engine"

##
# Anoubis library
module Anoubis
  module HasManualOrder
    extend ActiveSupport::Concern

    included do

    end

    module ClassMethods
      def has_manual_order(params = {})
        send :cattr_accessor, :manual_order_options
        send :before_create, :manual_order_before_create_element
        send :before_update, :manual_order_before_update_element
        send :after_save, :manual_order_after_save_element
        send :after_destroy, :manual_order_after_destroy

        self.manual_order_options = params if params.is_a?(Hash)
        include Anubis::HasManualOrder::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      # Check presence of position
      def manual_order_before_create_element
#        puts 'manual_order_before_create_element'
        position = self.manual_order_options[:field].to_sym  # set order field for simplicity
        if !self[position]
          data = self.class.where(manual_order_get_where).maximum(position)
          data = if data then data + 1 else 0 end
          self[position] = data
        else
          self[position] = 0 if self[position].to_i < 0 # position must be 0 or greater
          manual_order_check_order_position 0
        end
      end

      def manual_order_before_update_element
#        puts self.id.to_s+'> manual_order_before_update_element'
        if manual_order_changed_orders
          position = self.manual_order_options[:field].to_sym  # set order field for simplicity
          if !manual_order_changed_group
#            puts self.id.to_s+'> Group was not changed'
            was_position = eval('self.'+position.to_s+'_was')
#            puts self.id.to_s+'> Position changed: '+was_position.to_s+' -> '+self[position].to_s
            if self[position] > was_position
              order_where = manual_order_get_where
              order_where[position] = was_position.to_i
              data = self.class.where(order_where).where.not(:id => self.id).first
              if !data
#                puts self.id.to_s+'> Update attributes'
                self.update_columns position => self[position]
                order_where[position] = [was_position.to_i..self[position].to_i]
                self.class.where(order_where).where.not(:id => self.id).order(position).all.each  do |element|
#                  puts self.id.to_s+'> Element id: '+element.id.to_s+' -> '+element[position].to_s
                  element[position] -= 1
                  begin
                    element.current_user = self.current_user
                  rescue
                    puts 'Cant set current_user'
                  end
                  element.save
                end
              end
            end

          end
          if self[self.manual_order_options[:field].to_sym] != 0
            manual_order_check_order_position self.id
          end
        end
      end

      # Check manual order position
      def manual_order_check_order_position (id)
#        puts self.id.to_s+'> manual_order_check_order_position'
        position = self.manual_order_options[:field].to_sym  # set order field for simplicity
        if self[position].to_i > 0
          order_where = manual_order_get_where
          # Check if elements present for order conditions (before current element position)
          order_where[position] = [0..self[position].to_i-1]
          data = self.class.where(order_where).where.not(:id => id).maximum(position)
          if !data
            self[position] = 0 # if elements not found then position equal 0
          else
            self[position] = data+1 if self[position] != data+1 # if previous elements ends before position-1 then correct current position
          end
        end
      end

      # Recalculate position of elements after set current position
      def manual_order_after_save_element
        if manual_order_changed_orders
#          puts self.id.to_s+'> manual_order_after_save_element'
          position = self.manual_order_options[:field].to_sym  # set order field for simplicity
          order_where = manual_order_get_where
          order_where[position] = self[position]
          count = 0
          self.class.where(order_where).where.not(:id => self.id).find_each do |element|
#            puts self.id.to_s+'> Increment element position: '+element.id.to_s
            element[position] = self[position]+1
            begin
              element.current_user = self.current_user
            rescue
              puts 'Cant set current_user'
            end
            element.save
            count += 1
          end
          if manual_order_changed_group
            order_where = manual_order_get_where_was
            pos = eval('self.'+position.to_s+'_was').to_i
            order_where[position] = [pos..Float::INFINITY]
            self.class.where(order_where).order(position).all.each  do |element|
              element[position] = pos
              begin
                element.current_user = self.current_user
              rescue
                puts 'Cant set current_user'
              end
              element.save
              pos += 1
            end
          end
#if count == 0
#            order_where[position] = [self[position]+2..Float::INFINITY]
#            data = self.class.where(order_where).where.not(:id => self.id).order(position).first
#            if data
#              data[position] = self[position]+1
#              data.save
#            end
#          end
        end
      end

      # Recalculate positions after destroy element
      def manual_order_after_destroy
        position = self.manual_order_options[:field].to_sym  # set order field for simplicity
        order_where = manual_order_get_where
        pos = self[position]
        order_where[position] = [pos..Float::INFINITY]
        self.class.where(order_where).order(position).all.each  do |element|
          element[position] = pos
          begin
            element.current_user = self.current_user
          rescue
            puts 'Cant set current_user'
          end
          element.save
          pos += 1
        end
      end

      # Check if element's position was changed (or changed order group)
      def manual_order_changed_orders
        changed = eval('self.'+self.manual_order_options[:field].to_s+'_changed?')
        if self.manual_order_options.key? :groups
          self.manual_order_options[:groups].each do |key|
#            puts 'self.'+key.to_s+'_changed?'
            changed = eval('self.'+key.to_s+'_changed?') if !changed
          end
        end
#        puts 'manual_order_changed_orders: '+changed.to_s
        return changed
      end

      # Check if element's position changed in current order group
      def manual_order_changed_group
        changed = false
        if self.manual_order_options.key? :groups
          self.manual_order_options[:groups].each do |key|
#            puts 'self.'+key.to_s+'_changed?'
            changed = eval('self.'+key.to_s+'_changed?') if !changed
          end
        end
#        puts 'manual_order_changed_group: '+changed.to_s
        return changed
      end

      def manual_order_get_where
        where = {}
        if self.manual_order_options.key? :groups
          self.manual_order_options[:groups].each do |key|
            where[key.to_sym] = self[key.to_sym]
          end
        end
        return where
      end

      def manual_order_get_where_was
        where = {}
        if self.manual_order_options.key? :groups
          self.manual_order_options[:groups].each do |key|
            str = 'self.class.'+key.to_s.pluralize
            begin
#              puts str+'[(self.'+key.to_s+'_was).to_sym]'
              where[key.to_sym] = eval(str+'[(self.'+key.to_s+'_was).to_sym]')
            rescue
#              puts 'self.'+key.to_s+'_was'
              where[key.to_sym] = eval('self.'+key.to_s+'_was')
            end
          end
        end
        return where
      end
    end
  end
end

ActiveRecord::Base.send :include, Anoubis::HasManualOrder