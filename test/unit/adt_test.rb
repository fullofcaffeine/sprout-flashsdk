require 'test_helper'

class ADTTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "An ADT tool" do

    setup do
      @fixture              = File.join 'test', 'fixtures', 'air', 'simple'
      @application_xml      = File.join @fixture, 'SomeProject.xml'
      @expected_output      = File.join @fixture, 'SomeProject.air'
      @apk_input            = File.join @fixture, 'SomeProject.apk'
      @ipa_output           = File.join @fixture, 'SomeProject.ipa'
      @swf_input            = File.join @fixture, 'SomeProject.swf'
      @swf_main             = File.join @fixture, 'SomeProject.mxml'
      @certificate          = File.join @fixture, 'SomeProject.pfx'
      @ipa_cert             = File.join @fixture, 'SomeProject.p12'
      @provisioning_profile = File.join @fixture, 'Profile.mobileprovision'
      @platform             = 'android'
      @target               = 'apk-debug'
      @appid                = 'com.foo.bar.SomeProject'
      @cert_password        = 'samplePassword'
    end

    teardown do
      clear_tasks
      remove_file @expected_output
    end

    should "package a SWF with an application.xml" do
      as_a_unix_system do
        t = adt @expected_output do |t|
          t.package        = true
          t.target         = @target
          t.package_input  = @application_xml
          t.package_output = @expected_output
          t.storetype      = 'PKCS12'
          t.keystore       = @certificate
          t.storepass      = @cert_password
          t.included_files << @swf_input
        end

        assert_equal "-package -storetype PKCS12 -keystore #{@certificate} " +
            "-storepass #{@cert_password} -target #{@target} " +
            "test/fixtures/air/simple/SomeProject.air " +
            "test/fixtures/air/simple/SomeProject.xml " +
            "test/fixtures/air/simple/SomeProject.swf", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end
    
    should "package a SWF and complex assets with an application.xml" do
      as_a_unix_system do
        t = adt @expected_output do |t|
          t.package        = true
          t.target         = @target
          t.package_input  = @application_xml
          t.package_output = @expected_output
          t.storetype      = 'PKCS12'
          t.keystore       = @certificate
          t.storepass      = @cert_password
          t.included_files << @swf_input
          t.file_options << 'bin path/to/asset.xml'
        end

        assert_equal "-package -storetype PKCS12 -keystore #{@certificate} " +
            "-storepass #{@cert_password} -target #{@target} " +
            "test/fixtures/air/simple/SomeProject.air " +
            "test/fixtures/air/simple/SomeProject.xml " +
            "test/fixtures/air/simple/SomeProject.swf " +
            "-C bin path/to/asset.xml", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end

    should "package an iOS swf with a provisioning profile" do
      as_a_unix_system do
        t = adt @ipa_output do |t|
          t.package        = true
          t.target         = 'ipa-test'
          t.package_input  = @application_xml
          t.package_output = @ipa_output
          t.storetype      = 'PKCS12'
          t.keystore       = @ipa_cert
          t.storepass      = @cert_password
          t.provisioning_profile = @provisioning_profile
          t.included_files << @swf_input
        end

        assert_equal "-package -storetype PKCS12 -keystore #{@ipa_cert} " +
            "-storepass #{@cert_password} -provisioning-profile " +
            "#{@provisioning_profile} -target ipa-test " +
            "test/fixtures/air/simple/SomeProject.ipa " +
            "test/fixtures/air/simple/SomeProject.xml " +
            "test/fixtures/air/simple/SomeProject.swf", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end

    should "install an APK" do
      as_a_unix_system do
        t = adt @expected_output do |t|
          t.installApp    = true
          t.platform      = @platform
          t.package       = true
          t.package_input = @apk_input
        end

        assert_equal "-installApp -platform #{@platform} -package #{@apk_input}", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end

    should "uninstall an APK" do
      as_a_unix_system do
        t = adt @expected_output do |t|
          t.uninstallApp = true
          t.platform     = @platform
          t.appid        = @appid
        end

        assert_equal "-uninstallApp -platform #{@platform} -appid #{@appid}", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end

    should "launch an app" do
      as_a_unix_system do
        t = adt @expected_output do |t|
          t.launchApp = true
          t.platform  = @platform
          t.appid     = @appid
        end

        assert_equal "-launchApp -platform #{@platform} -appid #{@appid}", t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @expected_output
      end
    end

    should "create a self-signed certificate" do
      as_a_unix_system do
        t = adt(@certificate) do |t|
          t.certificate = true
          t.cn          = 'SelfCertificate'
          t.key_type    = '2048-RSA'
          t.pfx_file    = @certificate
          t.password    = @cert_password
        end

        assert_equal '-certificate -cn SelfCertificate 2048-RSA test/fixtures/air/simple/SomeProject.pfx samplePassword', t.to_shell

        # Uncomment to actually run adt (much slower)
        #t.execute
        #assert_file @certificate
      end
    end

    # USE THIS METHOD TO CREATE THE INPUT SWF:
    #should "create an input swf" do
      #t = amxmlc @swf_input do |t|
        #t.input = @swf_main
      #end
      #t.execute
    #end
  end
end

