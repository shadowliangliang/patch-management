#
# Cookbook Name:: patch-management
# Recipe:: default
#
# Copyright 2014, Chef Software, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Load our package comparison helper
::Chef::Recipe.send(:include, PatchManagement::Helper)

node.default['patch-management']['audit-status'] = "started"

if node['patch-management']['packages'].is_a?(Hash)
	
	node['patch-management']['packages'].each do |pkg,vrs|
		
		if pkg_installed?(pkg)
			
				if pkg_newer?(pkg_version(pkg), "#{vrs}")
					log "Package '#{pkg}' is installed and at version #{vrs} or later (Installed: #{pkg_version(pkg)})."
				else
					log "Package '#{pkg}' is installed, but needs to be patched!"
					node.default['patch-management']['audit-status'] = "failed"
				end

		else
			log "Package '#{pkg}' is not installed!"
			node.default['patch-management']['audit-status'] = "failed"
		end
	
  end

else
	Chef::Log.warn('`node["patch-management"]["packages"]` must be a Hash.')
end


# If anything failed the audit, set "patched" to false. Otherwise set to true.
if node['patch-management']['audit_status'] == "failed"
  node.override['patch-management']['patched'] = false
else
  node.override['patch-management']['patched'] = true
end

node.default['patch-management']['audit-status'] = "complete"