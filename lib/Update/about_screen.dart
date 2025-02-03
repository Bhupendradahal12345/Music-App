
import 'package:shrayesh_patro/Update/check_update.dart';
import 'package:shrayesh_patro/Update/icons.dart';
import 'package:shrayesh_patro/Update/text_styles.dart';
import 'package:shrayesh_patro/Update/update.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../API/app_config.dart';
import '../Backup/gradient_containers.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .about,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(5.0),
            children: [
              ListTile(
                      leading: const Icon(Icons.design_services_rounded),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .person,
                        style: textStyle(context, bold: true)
                            .copyWith(fontSize: 15),
                      ),
                     subtitle: Text(
                         AppLocalizations.of(
                           context,
                         )!
                             .personSub,

                     ),
                      trailing:  Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .personSub1,
                      ),
                      ),

                    ListTile(
                      leading: const Icon(Icons.new_releases),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .version1,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                        subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .version1Sub,
                        ),
                      trailing: Text(
                        appConfig.codeName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),

                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .developer,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),


                      trailing: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .developerSub1,
                            style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                          const SizedBox(width: 8),
                          Icon(AdaptiveIcons.chevron_right)
                        ,],
                      ),
                      onTap: () => launchUrl(
                          Uri.parse('https://github.com/Bhupendradahal12345'),
                          mode: LaunchMode.externalApplication,),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .sourceCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .sourceCodeSub,
                      ),
                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse('https://github.com/Bhupendradahal12345/Music-App'),
                          mode: LaunchMode.externalApplication,),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .bugReport,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .bugReportSub,
                      ),
                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse(
                              'https://github.com/Bhupendradahal12345/Music-App/issues/new?assignees=&labels=bug&projects=&template=bug_report.yaml',),
                          mode: LaunchMode.externalApplication,),
                    ),
                    ListTile(
                      leading: const Icon(Icons.request_page),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .featureRequest,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .featureRequestSub,
                      ),
                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse(
                              'https://github.com/Bhupendradahal12345/Music-App/issues/new?assignees=sheikhhaziq&labels=enhancement%2CFeature+Request&projects=&template=feature_request.yaml',),
                          mode: LaunchMode.externalApplication,),
                    ),
                    ListTile(
                      leading: const Icon(Icons.update_outlined),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .softwareUpdate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .softwareUpdateSub,
                      ),
                      trailing: Icon(AdaptiveIcons.chevron_right),
                        onTap: () {
                          Update.showCenterLoadingModal(context);
                          checkUpdate().then((updateInfo) {
                            Navigator.pop(context);
                            Update.showUpdateDialog(context, updateInfo);
                          },
                          );
                        }

                    ,),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),

                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
