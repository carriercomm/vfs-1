# 
# Very quick, dirty and uneficient In Memory FS, mainly for tests.
# 
module Vfs
  module Drivers
    class HashFs < Hash
      # 
      # Attributes
      # 
      def attributes path
        base, name = split_path path
        
        stat = cd(base)[name]
        attrs = {}
        attrs[:file] = !!stat[:file]
        attrs[:dir] = !!stat[:dir]
        attrs
      rescue Exception
        nil
      end
      
      def set_attributes path, attrs      
        raise 'not supported'
      end
      
      
      # 
      # File
      #       
      def read_file path, &block
        base, name = split_path path
        assert cd(base)[name], :include?, :file
        block.call cd(base)[name][:content]
      end
      
      def write_file path, &block
        base, name = split_path path
        assert_not cd(base), :include?, name
        
        os = ""
        callback = -> buff {os << buff}
        block.call callback

        cd(base)[name] = {file: true, content: os}
      end
      
      def delete_file path
        base, name = split_path path
        assert cd(base)[name], :include?, :file
        cd(base).delete name
      end
      
      def move_file path
        raise 'not supported'
      end
    
      
      # 
      # Dir
      #
      def create_dir path
        base, name = split_path path
        assert_not cd(base), :include?, name
        cd(base)[name] = {dir: true}
      end
    
      def delete_dir path
        base, name = split_path path        
        assert cd(base)[name], :include?, :dir
        cd(base).delete name
      end      
      
      def move_dir path
        raise 'not supported'
      end
      
      # def upload_directory from_local_path, to_remote_path
      #   FileUtils.cp_r from_local_path, to_remote_path
      # end
      # 
      # def download_directory from_remote_path, to_local_path
      #   FileUtils.cp_r from_remote_path, to_local_path
      # end
      
      
      # 
      # tmp
      # 
      def tmp &block
        tmp_dir = "/tmp_#{rand(10**6)}"
        create_dir tmp_dir
        if block
          begin
            block.call tmp_dir
          ensure
            delete_dir tmp_dir
          end
        else          
          tmp_dir
        end
      end
      
      protected
        def assert obj, method, arg          
          raise "#{obj} should #{method} #{arg}" unless obj.send method, arg
        end
        
        def assert_not obj, method, arg
          raise "#{obj} should not #{method} #{arg}" if obj.send method, arg
        end
      
        def split_path path
          parts = path[1..-1].split('/')

          name = parts.pop          
          return parts, name
        end
      
        def cd parts
          current = self
          iterator = parts.clone
          while iterator.first
            current = current[iterator.first]
            iterator.shift
          end    
          current
        end
    end
  end
end