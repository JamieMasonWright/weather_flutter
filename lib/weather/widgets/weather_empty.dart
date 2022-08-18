import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../weather/weather.dart';
class WeatherEmpty extends StatelessWidget {
  const WeatherEmpty({super.key});
  static Route route(WeatherBloc weatherBloc) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: weatherBloc,
        child: const WeatherEmpty(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<WeatherBloc, WeatherState>(
          buildWhen: (previous, current) =>
          previous.temperatureUnits != current.temperatureUnits,
          builder: (context, state) {
            return ListTile(
              title: const Text('Temperature Units'),
              isThreeLine: true,
              subtitle: const Text(
                'Use metric measurements for temperature units.',
              ),
              trailing: Switch(
                value: state.temperatureUnits.isCelsius,
                onChanged: (_) => context
                    .read<WeatherBloc>()
                    .add(const WeatherEvent.unitsChanged()),
              ),
            );
          },
        ),
     /*   SizedBox(height: MediaQuery.of(context).size.height * 0.25,),
        const Text('🏙️', style: TextStyle(fontSize: 64)),
        Text(
          'Please Select a City!',
          style: theme.textTheme.headline5,
        ),*/
      ],
    );
  }
}
