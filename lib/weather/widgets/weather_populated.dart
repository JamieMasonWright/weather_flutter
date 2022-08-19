import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../weather.dart';

class WeatherPopulated extends StatefulWidget {
  const WeatherPopulated({
    super.key,
    required this.weather,
    required this.units,
    required this.onRefresh,
  });

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;
  static Route route(WeatherBloc weatherBloc) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: weatherBloc,
        child: const WeatherEmpty(),
      ),
    );
  }
  @override
  State<WeatherPopulated> createState() => _WeatherPopulatedState();
}

class _WeatherPopulatedState extends State<WeatherPopulated> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [


        _WeatherBackground(),
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  _WeatherIcon(condition: widget.weather.condition),
                  Text(
                    widget.weather.location,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline2?.copyWith(
                      fontWeight: FontWeight.w200,
                    ),
                  ),

                  Text(
                    widget.weather.formattedTemperature(widget.units),
                    style: theme.textTheme.headline3?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '''Last Updated at ${TimeOfDay.fromDateTime(widget.weather.lastUpdated).format(context)}''',
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 45,
            margin: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 5.0,right: 5.0),
            decoration: BoxDecoration(

                border: Border.all(
                  color: Colors.black38,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'City',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('searchPage_search_iconButton'),
                  icon: const Icon(Icons.search),
                  onPressed: () => {
                    context.read<WeatherBloc>().add(WeatherEvent.started(_text))
                  },
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(padding: EdgeInsets.only(bottom: 20),
            child: BlocBuilder<WeatherBloc, WeatherState>(
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
            ),),
        )
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({Key? key, required this.condition}) : super(key: key);

  static const _iconSize = 100.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '❄️';
      case WeatherCondition.foggy:
        return '🌫️';
      case WeatherCondition.unknown:
      default:
        return '❓';
    }
  }
}

class _WeatherBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.25, 0.75, 0.90, 1.0],
          colors: [
            color,
            color.brighten(10),
            color.brighten(33),
            color.brighten(50),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color brighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}''';
  }
}
