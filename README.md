<img src="https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/openBaton.png" width="250"/>

Copyright © 2015-2016 [Open Baton](http://openbaton.org). Licensed under [Apache v2 License](http://www.apache.org/licenses/LICENSE-2.0).


# Tutorial: Clearwater Network Service Record

This tutorial shows how to deploy a Network Service Record composed by 8 VNFs, the basic Clearwater IMS.

Compared to the [Iperf-Server - Iperf-Client](http://openbaton.github.io/documentation/iperf-NSR/) and [OpenIMSCore](http://openbaton.github.io/documentation/ims-NSR/) the example provided here is even more complex. So, we assume you have practiced with other tutorials and you are familiar with the terminology used.


## Requirements

In order to execute this scenario, you need to have the following components up and running: 
 
 * [NFVO]
 * [Generic VNFM](http://openbaton.github.io/documentation/vnfm-generic/)
 * [Openstack-Plugin][openstack-plugin]

## Store the VimInstance

Upload a VimInstance to the NFVO (e.g. this [VimInstance]). 
 
## Prepare the VNF Packages

Download the necessary [files][vnf-package] from the [github repository][clearwater-repo] and pack the [VNF Packages](http://openbaton.github.io/documentation/vnfpackage/) for all 8 components ( cw_bind9, cw_fhoss, bono, dime, ellis, homer, sprout, vellum ). 

***For this example we assume the network used to interconnect the components is called "mgmt", if you want to modify this example ensure you are naming the network accordingly, the scripts from the github do not fully handle different network names yet. ***

The deployment_flavor is optional but should containg enough RAM for the default configuration of the components to be able to run, else some components may crash on start. This example setup has been successfuly tested on clean [Ubuntu14.04 images](https://cloud-images.ubuntu.com/) with 2048 Mb RAM on vellum and 1024 Mb RAM for all other components.

Finally onboard the packages via the Open Baton dashboard. 

## Store the Network Service Descriptor

Download the following [NSD] and upload it to the NFVO either using the dashboard or the cli. 
Take care to replace the vnfd ids with the ones you have on the VNFD catalogue (`Catalogue -> VNF Descriptors`).


## Deploy the Network Service Descriptor 

Deploy the stored NSD either using the dashboard (explained here))or the CLI. 

You need to go again to the GUI, go to `Catalogue -> NS Descriptors`, and open the drop down menu by clicking on `Action`. Afterwards you need to press the `Launch` button in order to start the deployment of this NSD.

If you go to `Orchestrate NS -> NS Records` in the menu on the left side, you can follow the deployment process and check the current status of the deploying NSD.

## Conclusions

Once the Network Service Record goes to "ACTIVE" your [Clearwater-IMS](http://www.projectclearwater.org/) - [Bind9](https://wiki.ubuntuusers.de/DNS-Server_Bind) - [FHoSS](http://www.openimscore.org/) deployment is finished.

![clearwater-ims-deployment][clearwater-struc]

To test your [Clearwater-IMS](http://www.projectclearwater.org/) you may use a SIP client of your choice. Be sure to use the realm defined in your [Bind9 Virtual Network Function Descriptor][bind9-vnf] 
while testing registration and call. By default the [FHoSS](http://www.openimscore.org/) conaints 2 users : alice and bob. The user is the same as the password, but you may also alter it to your needs modifying the [FHoSS Virtual Network Function Descriptor][openims-repo] ( You will find the users in "var_user_data.sql" file under the fhoss folder), or provision new users following the guidelines provided on the openimscore.org website. 

The default scenario contains alice and bob configured to use sip-digest authentication. We used [jitsi](https://jitsi.org/) for testing a video call between alice and bob, you can follow this [example](https://docs.opencloud.com/ocdoc/books/sentinel-volte-documentation/2.6.0/sentinel-volte-in-the-cloud/index-full.html#jitsijitsi) to properly configure your jitsi.

The complete deployment took about 12 minutes on an all-in-one OpenStack instance with i7 and 32 GB of RAM. This version does not support yet the [elastic scaling](http://clearwater.readthedocs.io/en/stable/Clearwater_Elastic_Scaling.html) which are planned for future releases. 


## Issue tracker

Issues and bug reports should be posted to the GitHub Issue Tracker of this project

# What is Open Baton?

Open Baton is an open source project providing a comprehensive implementation of the ETSI Management and Orchestration (MANO) specification and the TOSCA Standard.

Open Baton provides multiple mechanisms for interoperating with different VNFM vendor solutions. It has a modular architecture which can be easily extended for supporting additional use cases. 

It integrates with OpenStack as standard de-facto VIM implementation, and provides a driver mechanism for supporting additional VIM types. It supports Network Service management either using the provided Generic VNFM and Juju VNFM, or integrating additional specific VNFMs. It provides several mechanisms (REST or PUB/SUB) for interoperating with external VNFMs. 

It can be combined with additional components (Monitoring, Fault Management, Autoscaling, and Network Slicing Engine) for building a unique MANO comprehensive solution.

## Source Code and documentation

The Source Code of the other Open Baton projects can be found [here][openbaton-github] and the documentation can be found [here][openbaton-doc] .

## News and Website

Check the [Open Baton Website][openbaton]
Follow us on Twitter @[openbaton][openbaton-twitter].

## Licensing and distribution
Copyright © [2015-2016] Open Baton project

Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Support
The Open Baton project provides community support through the Open Baton Public Mailing List and through StackOverflow using the tags openbaton.

## Supported by
<img src="https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/fokus.png" width="250"/><img src="https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/tu.png" width="150"/>

<!---
References
-->

[NSD]: descriptors/tutorial-clearwater-ims-NSD/tutorial-clearwater-ims.json
[VimInstance]: descriptors/vim-instance/openstack-vim-instance.json
[NFVO]: https://github.com/openbaton/NFVO
[openstack-plugin]:https://github.com/openbaton/openstack-plugin
[bind9-vnf]: bind9/vnfd.json
[clearwater-struc]:images/clearwater_architecture.png
[vnf-package]:http://openbaton.github.io/documentation/vnfpackage/
[clearwater-repo]:https://github.com/openbaton/clearwater-packages


[fokus-logo]: https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/fokus.png
[cli-documentation]:http://openbaton.github.io/documentation/nfvo-how-to-use-cli/
[sdk-documentation]:http://openbaton.github.io/documentation/nfvo-sdk/
[openbaton]: http://openbaton.org
[openbaton-doc]: http://openbaton.org/documentation
[openbaton-github]: http://github.org/openbaton
[openbaton-logo]: https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/openBaton.png
[openbaton-mail]: mailto:users@openbaton.org
[openbaton-twitter]: https://twitter.com/openbaton
[tub-logo]: https://raw.githubusercontent.com/openbaton/openbaton.github.io/master/images/tu.png

