require 'net/ftp'


class RecursiveFTP
	@@dir_regex = /^d[r|w|x|-]+\s+[0-9]\s+\S+\s+\S+\s+\d+\s+\w+\s+\d+\s+[\d|:]+\s(.+)/
	@@file_regex = /^[r|w|x|-]+\s+[0-9]\s+\S+\s+\S+\s+\d+\s+\w+\s+\d+\s+[\d|:]+\s(.+)/
		
	def initialize(host) 
		@ftp = Net::FTP.new(host)
		@ftp.passive = true
	end
	
	def login(username, password)
		@ftp.login(username, password)
	end		

	# Recursively downloads a remote directory
	def download_dir(remote_dir, local_dir)		
		puts "Downloading remote dir " + remote_dir + " to local dir " + local_dir
		@ftp.chdir(remote_dir)
		items = @ftp.ls
		directories = Array.new
		files = Array.new
		
		items.each do |line|
			if dir = line.match(@@dir_regex)
				if dir[1].eql?(".") || dir[1].eql?("..")
					items.delete(dir)
				else
					directories.push(dir[1])
				end
			elsif file = line.match(@@file_regex)
				files.push(file[1])	
			end	
			#items.delete(line)
		end
	
		puts "Downloading files from " + @ftp.pwd + "..."

		files.each do |file|
			puts "\tFile: " + file
			@ftp.gettextfile(file, local_dir + file)
		end
		puts "Downloading directories from " + @ftp.pwd + "..."
		directories.each do |dir|
			if !File.directory?(local_dir + dir)
				puts "Creating local dir " + local_dir + dir
				Dir.mkdir(local_dir + dir)
			end
			dir << "/"
			download_dir(remote_dir + dir, local_dir + dir)
		end
		@ftp.chdir("./")
	end
	
	# Recursively uploads a local directory
	def upload_dir(local_dir, remote_dir)	
		puts "Uploading local dir " + local_dir + " to remote dir " + remote_dir	
		@ftp.mkdir(remote_dir)
		rescue Net::FTPPermError
			@ftp.chdir(remote_dir)
			
		dir = Dir.new(local_dir)
		
		dir.each do |filename| 
			if filename != "." && filename != ".." && !File.directory?(local_dir + filename)
				puts "\tFile: " + local_dir + filename
				@ftp.puttextfile(local_dir + filename, remote_dir + filename)
			elsif filename != "." && filename != ".." && File.directory?(local_dir + filename)
				upload_dir(local_dir + filename + "/", remote_dir + filename + "/")
			end	
		end
	end
end

