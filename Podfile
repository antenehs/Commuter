platform :ios, '9.0'
# Or platform :osx, '10.7'

#link_with [‘Reitti’, ‘Reitti Pro’, ‘Commuter - Departures’, ‘Commuter - Departures Pro’ , ‘Commuter - Routes Pro’]

#pod 'RestKit', '~> 0.24.0’
#pod 'RKXMLReaderSerialization', :git => 'https://github.com/RestKit/RKXMLReaderSerialization.git', :branch => 'master'
#
#pod 'Google/Analytics'

def networking_pods
  pod 'RestKit', '~> 0.24.0’
	pod 'RKXMLReaderSerialization', :git => 'https://github.com/RestKit/RKXMLReaderSerialization.git', :branch => 'master'
end

def analytics_pods
  pod 'Google/Analytics'
  pod 'Firebase/Core'
end

def crash_reporting
  pod 'Firebase/Crash'
end

def remote_config
  pod 'Firebase/RemoteConfig'
end

def push_notification
  pod 'Firebase/Messaging'
end

def arc_gis
  pod ‘ArcGIS-Runtime-SDK-iOS’, '~> 10.2.5'
end

abstract_target 'Networking' do
  networking_pods

	target 'Commuter - Departures'
	target 'Commuter - Departures Pro'

	target 'Commuter - Routes Pro' do
  end

	target 'Reitti' do
		analytics_pods
    crash_reporting
    remote_config
    push_notification
    arc_gis
  end

  target 'Reitti Pro' do
  	analytics_pods
    crash_reporting
    remote_config
    push_notification
    arc_gis
  end

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts "#{target.name}"
  end
end
